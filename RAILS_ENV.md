There is something wrong about RAILS_ENV.

By the way this applies to other web frameworks.
[Rails](https://rubyonrails.org/) introduced it and it spead around.

It took me a long time to translate that feeling of "wrong" into words but
here it is. It's a semantic issue.

> RAILS_ENV is encouraging to mix two meanings together, a "running mode" and
a "deployment target"

It's quite subtle and infiltrates the whole ecosystem.

## RAILS_ENV is a running mode

The purpose of RAILS_ENV is to select different runtime defaults. During
development you want a lot of debug information but not when deployed to
production. Testing might want to disable some of the external dependencies.

If vim was a rails app, it would start with `--debug` by default.

Because of the value naming choice, "production" in particular will lead some
of the developers to confuse it with the actual deployment target.

## RAILS_ENV=production by default is bad

The application should be safe to run by default. Because Rails favours
developer convenience over security, all Rails deployments now run the risk of
forgetting to set `RAILS_ENV=production` and ship with backtraces and other
risk features that can expose system credentials.

All this to save typing two characters like `-d` to enable the debug mode.

## RAILS_ENV=staging is wrong

Because the developer had confused deployment target to running mode I have
seen plenty of "staging" environments.

Staging is supposed to be as close to production as possible. How can you test
this if there is different code being loaded for staging?

Inevitably the staging environment will diverge and create production issues.

## RAILS_ENV encourages embedded credentials

Most web shops have a single production deployment. It becomes very tempting
to switch on `Rails.env.production?` and embed configuration and credentials.


# Proposed solution

1. Rename `Rails.env` to `Rails.mode`.
2. Rename the possible values to "normal", "debug" and "testing"
3. Select "normal" mode by default.
4. (Optional) Remove the ability to add new runtime modes

