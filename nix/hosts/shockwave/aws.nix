{
    "sso-session work-sso" = {
        sso_start_url = "https://d-0123456789.awsapps.com/start/#";
        sso_region = "us-east-1";
    };

    "profile work-dev" = {
        sso_session = "work-sso";
        sso_role_name = "work-role";
        sso_account_id = "012345678901";
        region = "us-east-1";
        output = "json";
    };
}
