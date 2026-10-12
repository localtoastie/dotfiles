{
    "sso-session xyz-session-sso" = {
        sso_start_url = "https://d-0123456789.awsapps.com/start/#";
        sso_region = "us-east-1";
    };

    "profile xyz" = {
        sso_session = "xyz-session-sso";
        sso_role_name = "xyz-role";
        sso_account_id = "012345678901";
        region = "us-east-1";
        output = "json";
    };
}
