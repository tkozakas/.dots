#!/usr/bin/env bash
# nvim smoke test: config loads without errors and an LSP client initializes.
# Usage: nvim-smoke.sh [FILE] [TIMEOUT_MS]
set -euo pipefail

FILE="${1:-$HOME/vinted/core/app/models/user.rb}"
TIMEOUT="${2:-60000}"

echo "1/2 startup..."
out="$(nvim --headless "+lua vim.defer_fn(vim.cmd.qa, 200)" 2>&1 || true)"
if [ -n "$out" ]; then
    echo "FAIL: startup noise:"
    printf '%s\n' "$out"
    exit 1
fi
echo "    clean"

echo "2/2 lsp init on $FILE..."
cd "$(dirname "$FILE")"
nvim --headless "$FILE" +"lua (function()
    local start = vim.uv.now()
    local t = vim.uv.new_timer()
    t:start(500, 500, vim.schedule_wrap(function()
        local c = vim.lsp.get_clients({ bufnr = 0 })[1]
        if c and c.initialized then
            print(('    %s initialized in %dms\n'):format(c.name, vim.uv.now() - start))
            t:stop(); vim.cmd.qa()
        elseif vim.uv.now() - start > $TIMEOUT then
            print('FAIL: no LSP client initialized in ${TIMEOUT}ms')
            t:stop(); vim.cmd.cquit()
        end
    end))
end)()" 2>&1
echo "OK"
