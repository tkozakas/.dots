-- Detect all Jenkinsfile variants as groovy filetype
-- This will match:
--   - Jenkinsfile
--   - Jenkinsfile.dev
--   - Jenkinsfile.prod
--   - Jenkinsfile.staging
--   - ci/Jenkinsfile.dev
--   - etc.

vim.filetype.add({
	pattern = {
		[".*Jenkinsfile.*"] = "groovy",
	},
})
