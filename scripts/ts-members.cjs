// Prints the fully merged members of the TypeScript symbol under the cursor.
// Usage: node ts-members.cjs <file> <line0> <col0>   (current buffer text on stdin)
// Exits 1 when there is nothing to show (functions, primitives), so the caller can
// fall back to the normal LSP hover.
const path = require("path");
const fs = require("fs");

const file = path.resolve(process.argv[2]);
const line = Number(process.argv[3]);
const col = Number(process.argv[4]);
const text = fs.readFileSync(0, "utf8");

let ts;
try {
  ts = require(require.resolve("typescript", { paths: [path.dirname(file)] }));
} catch {
  process.exit(1); // no TypeScript installed for this project
}

const configPath = ts.findConfigFile(path.dirname(file), ts.sys.fileExists);
const options = configPath
  ? ts.parseJsonConfigFileContent(ts.readConfigFile(configPath, ts.sys.readFile).config, ts.sys, path.dirname(configPath)).options
  : { strict: true, target: ts.ScriptTarget.ES2022 };

// Use the unsaved buffer text for the current file, disk for everything else.
const host = ts.createCompilerHost(options);
const readSourceFile = host.getSourceFile.bind(host);
host.getSourceFile = (f, lang, ...rest) =>
  path.resolve(f) === file ? ts.createSourceFile(f, text, lang, true) : readSourceFile(f, lang, ...rest);

const program = ts.createProgram([file], options, host);
const checker = program.getTypeChecker();
const sf = program.getSourceFile(file);
const pos = sf.getPositionOfLineAndCharacter(line, col);

function deepest(node) {
  const child = ts.forEachChild(node, (c) => (pos >= c.getStart(sf) && pos < c.getEnd() ? c : undefined));
  return child ? deepest(child) : node;
}
const node = deepest(sf);
if (!ts.isIdentifier(node)) process.exit(1);

let symbol = checker.getSymbolAtLocation(node);
if (!symbol) process.exit(1);
if (symbol.flags & ts.SymbolFlags.Alias) symbol = checker.getAliasedSymbol(symbol);

// `Error`, `ClosedError`, `Foo` -> the instance shape. `e`, `opts` -> the value's type.
const typeLike = ts.SymbolFlags.Class | ts.SymbolFlags.Interface | ts.SymbolFlags.TypeAlias;
const type = symbol.flags & typeLike ? checker.getDeclaredTypeOfSymbol(symbol) : checker.getTypeOfSymbolAtLocation(symbol, node);

const props = checker.getPropertiesOfType(type);
if (props.length === 0) process.exit(1);

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
console.log(out.join("\n"));
