#!/usr/bin/env bun
import { $ } from "bun";

if (["--help", "-h"].includes(Bun.argv[2] ?? "")) {
  console.log("usage: workspace-new [branch]\nWith no branch, uses the current directory.");
  process.exit(0);
}

const branch = Bun.argv[2];

const room = process.env.AGENT_GOSSIP_DEFAULT_ROOM;
if (!room) {
  console.error("AGENT_GOSSIP_DEFAULT_ROOM is not set");
  process.exit(2);
}

const worktreePath = async (branch: string) => {
  const result = await $`grove go ${branch} -p`.quiet().nothrow();
  return result.exitCode === 0 ? result.text().trim() : undefined;
};

const resolveDir = async () => {
  if (!branch) return process.cwd();
  const existing = await worktreePath(branch);
  if (existing) return existing;
  await $`grove add ${branch}`;
  return (await worktreePath(branch))!;
};

const dir = await resolveDir();

const quote = (text: string) => `'${text.replaceAll("'", `'\\''`)}'`;
const join = `/gossip-join ${room}`;
const founderPrompt =
  `${join} Then wait until 3 other peers are in the gossip. ` +
  `Then run /graph-up squad.`;
const claude = (model: string, prompt: string) =>
  `cl --model ${model} ${quote(prompt)}`;

const script = `
on run argv
  set dir to item 1 of argv
  tell application "Ghostty"
    set base to new surface configuration
    set initial working directory of base to dir

    set w to front window
    set origTab to selected tab of w
    set origTerminal to focused terminal of origTab

    set cfgSonnet to new surface configuration from base
    set initial input of cfgSonnet to (item 2 of argv) & linefeed
    set cfgHaiku to new surface configuration from base
    set initial input of cfgHaiku to (item 3 of argv) & linefeed
    set cfgOpus to new surface configuration from base
    set initial input of cfgOpus to (item 4 of argv) & linefeed

    set tAgents to new tab in w with configuration cfgSonnet
    set topLeft to focused terminal of tAgents
    perform action "set_tab_title:agents" on topLeft
    set topRight to split topLeft direction right with configuration cfgHaiku
    split topLeft direction down with configuration cfgHaiku
    split topRight direction down with configuration cfgOpus

    set cfgLg to new surface configuration from base
    set initial input of cfgLg to "lg" & linefeed
    new tab in w with configuration cfgLg

    set cfgVim to new surface configuration from base
    set initial input of cfgVim to "nvim" & linefeed
    new tab in w with configuration cfgVim

    select tab origTab
    focus origTerminal
  end tell
end run
`;

await $`osascript -e ${script} ${dir} ${claude("sonnet", founderPrompt)} ${claude("haiku", join)} ${claude("opus", join)}`;

console.log(dir);
