# Platform foundation

This documentation describes how we manage platform responsibilities for both Google Cloud Platform (GCP) and GitHub.

The goal is to:

- keep organisation and platform concerns out of individual application repositories
- make bootstrap and day to day operations reproducible and low friction
- stay cheap to run while still following sane patterns

The platform has two main pillars:

- **GCP foundation** for organisation, projects, state, secrets and CI identities
- **GitHub foundation** for organisation settings, core repositories, teams and branch protections

Application and service repositories consume these foundations but do not modify them.
