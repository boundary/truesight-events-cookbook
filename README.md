# truesight-events

A chef report handler that publishes to TrueSight Events. Your chef run data can be pushed to TrueSight Pulse, and TrueSight Intelligence.

## Supported Platforms

All

## Attributes

<table>
  <tr>
    <th>Key</th>
    <th>Type</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td><tt>['truesight_events']['email']</tt></td>
    <td>String</td>
    <td>Authentication email address</td>
    <td><tt>empty</tt></td>
  </tr>
  <tr>
    <td><tt>['truesight_events']['api_token']</tt></td>
    <td>String</td>
    <td>API Token</td>
    <td><tt>empty</tt></td>
  </tr>
</table>

## Usage

### truesight-events::default

Include `truesight-events` in your node's `run_list`:

```json
{
  "run_list": [
    "recipe[truesight-events::default]"
  ]
}
```
## Configuration

You may use the provided attributes or a chef databag

## Databag setup

Name: truesight
Id: account

Fields:
  - email
  - api_token

## License and Authors

License:: Apache 2.0
Author:: TrueSight Operations (<truesightops@bmc.com>)
