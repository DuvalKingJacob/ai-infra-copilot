import { execFile } from "node:child_process";
import { promisify } from "node:util";

const execFileAsync = promisify(execFile);

export function getTerraformContextProvider(args = process.argv.slice(2), env = process.env) {
  const flag = args.find((arg) => arg.startsWith("--terraform-context="));
  return flag?.split("=")[1] || env.TERRAFORM_CONTEXT_PROVIDER || "fixture";
}

export function getTfctlWorkspace(args = process.argv.slice(2), env = process.env) {
  const flag = args.find((arg) => arg.startsWith("--workspace="));
  return flag?.split("=")[1] || env.TFCTL_WORKSPACE || null;
}

export function stripTerraformContextArgs(args) {
  return args.filter(
    (arg) => !arg.startsWith("--terraform-context=") && !arg.startsWith("--workspace=")
  );
}

export async function getTfctlReadOnlyContext({ workspace }) {
  if (!workspace) {
    return {
      source: "tfctl",
      status: "skipped",
      reason: "Set --workspace=<name> or TFCTL_WORKSPACE to enable read-only tfctl context.",
    };
  }

  const results = {
    source: "tfctl",
    status: "ok",
    workspace,
    runStatus: await runTfctl(["run", "status", workspace]),
    variables: await runTfctl([
      "api",
      "/workspaces/{workspace}/vars",
      "-p",
      `workspace=${workspace}`,
      "--jq",
      ".data[] | {key: .attributes.key, category: .attributes.category, sensitive: .attributes.sensitive}",
    ]),
  };

  if (results.runStatus.exitCode !== 0 || results.variables.exitCode !== 0) {
    results.status = "partial";
  }

  return results;
}

async function runTfctl(args) {
  try {
    const { stdout, stderr } = await execFileAsync("tfctl", args, { timeout: 15000 });
    return {
      command: ["tfctl", ...args].join(" "),
      exitCode: 0,
      stdout: stdout.trim(),
      stderr: stderr.trim(),
    };
  } catch (error) {
    return {
      command: ["tfctl", ...args].join(" "),
      exitCode: typeof error.code === "number" ? error.code : 1,
      stdout: error.stdout?.trim() || "",
      stderr: error.stderr?.trim() || error.message,
    };
  }
}
