# Simple health checker

A simple bash script to check HTTP server.

1. Checking HTTP server responses with `2xx` status
2. Checking HTTP server response body includes target string

![Discord webhook result](https://cdn.discordapp.com/attachments/1102888096007196733/1102938780178059265/image.png)

## Why I did this

I am running my own server at my home, and I do test experimental things before applying them to production.\
This is a simple script to test I messed up something.

## Usage

```sh
bash run.sh [options]
```

### Options

| Option              | Usage     | Description                                                                              | Default |
| ------------------- | --------- | ---------------------------------------------------------------------------------------- | ------- |
| M(mode)             | arguments | Mode to run script. You can use `local` or `actions`                                     | local   |
| DISCORD_WEBHOOK_URI | config    | URL of discord webhook. Click `Copy Webhook URL` in webhooks                             | -       |
| TIMEOUT             | config    | Notifies you when curl takes longer time than `TIMEOUT`ms even if server returns 200 OK. | 500     |

### Local server setting

```md
-   config.sh
-   HTTP_STATUS_CHECK (optional)
-   HTTP_RESPONSE_CHECK (optional)
```

The list of files you need to add.\
Please place every file at root directory of this project.

```sh
#!/bin/bash

export DISCORD_WEBHOOK_URI='https://discord.com/api/webhooks/123/foo'
export TIMEOUT='1500'
```

Example of `config.sh`.\
Please notice that `DISCORD_WEBHOOK_URI` is necessary to run this script.

```txt
https://example.com
https://marshallku.com
```

Example of `HTTP_STATUS_CHECK` file.\
Add the address to be checked separately by line breaks.

```txt
https://example.com RESPONSE_STATUS 200 RESPONSE_INCLUDES FOO RESPONSE_NOT_INCLUDES BAR
https://example.com RESPONSE_STATUS 404 RESPONSE_INCLUDES FOO
https://example.com RESPONSE_INCLUDES BAZ
https://example.com RESPONSE_STATUS 200 RESPONSE_NOT_INCLUDES FIZZ
```

Example of `HTTP_RESPONSE_CHECK` file.

| Option                | Description                                                          |
| --------------------- | -------------------------------------------------------------------- |
| RESPONSE_STATUS       | The expected HTTP response status code                               |
| RESPONSE_INCLUDES     | Characters that expected to be included in the response body         |
| RESPONSE_NOT_INCLUDES | Characters that are NOT expected to be included in the response body |

### Github actions setting

1. Comment in `schedule` in `.github/workflows/health-check.yml`
2. Add configs(eg. `TIMEOUT`, `HTTP_STATUS_CHECK`) in Actions Secrets
