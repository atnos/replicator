# Replicator

This project allow you to restore the last Scalingo PostgreSQL backup in an another app.

The app need to have a PostgreSQL addon and 2 env variables set:
- `SCALINGO_CLI_TOKEN` that you can create here https://dashboard.scalingo.com/account/tokens
- `SOURCE_APP` the name of the app where the backup will be fetched
- `APPSIGNAL_APP_PUSH_API_KEY` the AppSignal app-level Push API key ("Push & Deploy" settings)

The scheduled job (`cron.json`) runs `run.sh`, which installs [appsignal-wrap](https://docs.appsignal.com/wrap)
into `/app/bin` and runs `replicate.sh` through it, sending a cron check-in named `replicator` to AppSignal.
Create a cron check-in with the `replicator` identifier in AppSignal to be alerted when the job fails or doesn't run.

You also need to follow this documentation since our app won't have any web container (any container at all actually).
https://doc.scalingo.com/platform/app/web-less-app (spoiler `scalingo --app my-app scale web:0:M`)

The empty `index.php` file is a small hack in order for the app to be deployed.
