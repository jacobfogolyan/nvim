// Prints the fully merged members of the TypeScript symbol under the cursor.
//   One-shot: node ts-members.cjs <file> <line0> <col0>   (buffer text on stdin)
//             exits 1 when there is nothing to show (functions, primitives).
//   Server:   node ts-members.cjs --serve
//             reads one JSON request per line: {"file","line","col","text"}
//             writes one JSON reply per line:  {"out": string | null}
// The server keeps TypeScript loaded and caches parsed files (lib.*.d.ts and
// node_modules types) so each request skips the slow parse.
const path = require("path");
const fs = require("fs");
const readline = require("readline");

const tsByDir = new Map(); // project dir -> typescript module (or null)
const sourceCache = new Map(); // file name -> { mtimeMs, sf }

function loadTs(dir) {
  if (!tsByDir.has(dir)) {
    try {
      tsByDir.set(dir, require(require.resolve("typescript", { paths: [dir] })));
    } catch {
      tsByDir.set(dir, null); // no TypeScript installed for this project
    }
  }
  return tsByDir.get(dir);
}

function cachedSourceFile(ts, f, lang) {
  let mtimeMs;
  try {
    mtimeMs = fs.statSync(f).mtimeMs;
  } catch {
    return undefined;
  }
  const hit = sourceCache.get(f);
  if (hit && hit.mtimeMs === mtimeMs) return hit.sf;
  const sf = ts.createSourceFile(f, fs.readFileSync(f, "utf8"), lang, true);
  sourceCache.set(f, { mtimeMs, sf });
  return sf;
}

function members({ file, line, col, text }) {
  file = path.resolve(file);
  const ts = loadTs(path.dirname(file));
  if (!ts) return null;

  const configPath = ts.findConfigFile(path.dirname(file), ts.sys.fileExists);
  const options = configPath
    ? ts.parseJsonConfigFileContent(ts.readConfigFile(configPath, ts.sys.readFile).config, ts.sys, path.dirname(configPath)).options
    : { strict: true, target: ts.ScriptTarget.ES2022 };

  // Unsaved buffer text for the current file, the cache for everything else.
  const host = ts.createCompilerHost(options);
  host.getSourceFile = (f, lang) =>
    path.resolve(f) === file ? ts.createSourceFile(f, text, lang, true) : cachedSourceFile(ts, f, lang);

  const program = ts.createProgram([file], options, host);
  const checker = program.getTypeChecker();
  const sf = program.getSourceFile(file);
  if (!sf || line >= sf.getLineStarts().length) return null;
  const pos = sf.getPositionOfLineAndCharacter(line, col);

  const deepest = (node) => {
    const child = ts.forEachChild(node, (c) => (pos >= c.getStart(sf) && pos < c.getEnd() ? c : undefined));
    return child ? deepest(child) : node;
  };
  const node = deepest(sf);
  if (!ts.isIdentifier(node)) return null;

  let symbol = checker.getSymbolAtLocation(node);
  if (!symbol) return null;
  if (symbol.flags & ts.SymbolFlags.Alias) symbol = checker.getAliasedSymbol(symbol);

  // Where the name is used as a type (`: Error`, `extends Error`, `new Error()`, its own
  // declaration) show the instance shape. Used as a value (`Promise.reject`, `e`) show
  // that value's type, so `Promise` there lists reject/resolve/all, not then/catch.
  const p = node.parent;
  const usedAsType =
    ts.isTypeReferenceNode(p) ||
    ts.isExpressionWithTypeArguments(p) ||
    (ts.isNewExpression(p) && p.expression === node) ||
    ((ts.isClassLike(p) || ts.isInterfaceDeclaration(p) || ts.isTypeAliasDeclaration(p)) && p.name === node);
  const typeLike = ts.SymbolFlags.Class | ts.SymbolFlags.Interface | ts.SymbolFlags.TypeAlias;
  const type =
    usedAsType && symbol.flags & typeLike ? checker.getDeclaredTypeOfSymbol(symbol) : checker.getTypeOfSymbolAtLocation(symbol, node);

  const props = checker.getPropertiesOfType(type);
  if (props.length === 0) return null;

  // Printed as a real interface so the float gets proper TypeScript highlighting.
  const fmt = ts.TypeFormatFlags.NoTruncation;
  const typeName = checker.typeToString(type, undefined, fmt);
  const out = [];
  if (typeName !== node.text && !typeName.startsWith(`${node.text}<`)) out.push(`// ${node.text}: ${typeName}`);
  const declaredIn = [
    ...new Set((symbol.declarations ?? []).map((d) => path.basename(d.getSourceFile().fileName).replace(/^lib\.|\.d\.ts$|\.tsx?$/g, ""))),
  ];
  if (declaredIn.length > 1) out.push(`// merged from: ${declaredIn.join(", ")}`);
  out.push(/^[\w$.]+(<.*>)?$/.test(typeName) ? `interface ${typeName} {` : `type ${node.text} = {`);
  for (const prop of props) {
    // symbolToString turns internal keys like `__@toStringTag@33` into `[Symbol.toStringTag]`.
    const name = checker.symbolToString(prop);
    const optional = prop.flags & ts.SymbolFlags.Optional ? "?" : "";
    const propType = checker.getTypeOfSymbolAtLocation(prop, node);
    const signatures = propType.getCallSignatures();
    // Methods: one line per overload, written like `all<T>(values: ...): Promise<...>`.
    if (prop.flags & ts.SymbolFlags.Method && signatures.length > 0) {
      for (const sig of signatures) out.push(`  ${name}${optional}${checker.signatureToString(sig, undefined, fmt)};`);
    } else {
      out.push(`  ${name}${optional}: ${checker.typeToString(propType, undefined, fmt)};`);
    }
  }
  out.push("}");
  return out.join("\n");
}

function safeMembers(req) {
  try {
    return members(req);
  } catch {
    return null;
  }
}

if (process.argv[2] === "--serve") {
  readline.createInterface({ input: process.stdin }).on("line", (l) => {
    let out = null;
    try {
      out = safeMembers(JSON.parse(l));
    } catch {}
    process.stdout.write(JSON.stringify({ out }) + "\n");
  });
} else {
  const out = safeMembers({
    file: process.argv[2],
    line: Number(process.argv[3]),
    col: Number(process.argv[4]),
    text: fs.readFileSync(0, "utf8"),
  });
  if (out === null) process.exit(1);
  console.log(out);
}
