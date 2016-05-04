# truesight-events

A chef report handler that publishes to TrueSight Events. Your chef run data can be pushed to TrueSight Pulse, and TrueSight Intelligence.

## Supported Platforms

All

## Attributes

| Key | Type | Description | Default |
| --- | ---- | ----------- | ------- |
| `['truesight_events']['email']` | String | Authentication Email Address | empty |
| `['truesight_events']['api_token']` | String | API Token | empty |

## Usage

### truesight-events::default

Include `truesight-events` in your node's `run_list` preferably early as this is an exception and success reporter:

```json
{
  "run_list": [
    "recipe[truesight-events::default]"
  ]
}
```
## Configuration

You may use the provided attributes or a chef databag

## Databag Setup

Name: truesight
Id: account

Fields:
  - email
  - api_token

## License and Authors

License:: Apache 2.0
Author:: TrueSight Operations (<truesightops@bmc.com>)
