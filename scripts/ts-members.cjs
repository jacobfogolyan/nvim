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

  // `Error`, `ClosedError`, `Foo` -> the instance shape. `e`, `opts` -> the value's type.
  const typeLike = ts.SymbolFlags.Class | ts.SymbolFlags.Interface | ts.SymbolFlags.TypeAlias;
  const type = symbol.flags & typeLike ? checker.getDeclaredTypeOfSymbol(symbol) : checker.getTypeOfSymbolAtLocation(symbol, node);

  const props = checker.getPropertiesOfType(type);
  if (props.length === 0) return null;

  const fmt = ts.TypeFormatFlags.NoTruncation;
  const declaredIn = [...new Set((symbol.declarations ?? []).map((d) => path.basename(d.getSourceFile().fileName)))];
  const out = [`// ${node.text}: ${checker.typeToString(type, undefined, fmt)}`];
  if (declaredIn.length > 1) out.push(`// merged from ${declaredIn.join(", ")}`);
  out.push("{");
  for (const p of props) {
    const optional = p.flags & ts.SymbolFlags.Optional ? "?" : "";
    out.push(`  ${p.name}${optional}: ${checker.typeToString(checker.getTypeOfSymbolAtLocation(p, node), undefined, fmt)};`);
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
