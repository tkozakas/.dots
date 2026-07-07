-- Detect Jenkinsfile variants as groovy:
--   Jenkinsfile, ci/Jenkinsfile, Jenkinsfile.dev, ci/Jenkinsfile.prod, ...
-- NOTE: no `$` after the char class — nvim's filetype matcher silently
-- fails on patterns ending in `[...]+$`. The `%.` requirement is enough to
-- keep e.g. my-Jenkinsfile-notes.md / Jenkinsfiles.txt on their own types.
vim.filetype.add({
  filename = {
    ['Jenkinsfile'] = 'groovy',
  },
  pattern = {
    ['Jenkinsfile%.[%w_%-]+'] = 'groovy',
  },
})
