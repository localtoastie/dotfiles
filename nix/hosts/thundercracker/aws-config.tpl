# Rendered to ~/.aws/config by `just aws-config`.
# {{ op://... }} references are filled in from 1Password; never put real values here.

[sso-session xyz-session-sso]
sso_start_url = {{ op://Personal/aws-sso/start-url }}
sso_region = us-east-1

[profile xyz]
sso_session = xyz-session-sso
sso_account_id = {{ op://Personal/aws-sso/xyz-account-id }}
sso_role_name = {{ op://Personal/aws-sso/xyz-role }}
region = us-east-1
output = json
