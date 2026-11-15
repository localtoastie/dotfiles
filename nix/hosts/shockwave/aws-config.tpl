# Rendered to ~/.aws/config by `just aws-config`.
# {{ op://... }} references are filled in from 1Password; never put real values here.

[sso-session work-sso]
sso_start_url = {{ op://Work/aws-sso/start-url }}
sso_region = us-east-1

[profile work-dev]
sso_session = work-sso
sso_account_id = {{ op://Work/aws-sso/dev-account-id }}
sso_role_name = {{ op://Work/aws-sso/dev-role }}
region = us-east-1
output = json
