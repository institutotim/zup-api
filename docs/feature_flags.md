# Feature flags

The feature flag API allow admins to change the behaviour of the app itself, it counts with two endpoints, one for listing the feature flags and its status and the other one is to disable/enable a feature.

## Getting a list of the feature flags

To get it, it's very easy, just fetch through this endpoint:

`GET /feature_flags`

Thus, you'll get a response like this:

    {
      "flags": [
        {
          "id": 1,
          "name": "explore",
          "status_name": "disabled"
        },
        {
          "id": 2,
          "name": "create_report_clients",
          "status_name": "disabled"
        },
        {
          "id": 3,
          "name": "create_report_panel",
          "status_name": "disabled"
        },
        {
          "id": 4,
          "name": "stats",
          "status_name": "disabled"
        },
        ...
      ]
    }

### Enabling/disabling a feature flag

You can enable or disable a feature flag by requesting to this endpoint:

`PUT /feature_flags/:feature_flag_id`

With this content:

    {
      status: 1
    }

If you want to enable, set the `status` to 1, if you want to disable, set to 0.
