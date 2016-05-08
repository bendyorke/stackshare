# StackShare Recommendation Engine

Select your business type, and see what stack you should use.

## Development

1. Clone this repo
2. Obtain an api key from api.stackshare.io
3. Copy `env.sample` to `.env`, and add your `STACKSHARE_ACCESS_TOKEN`
4. Run `rake fetch:tags fetch:layers`
4. Run `rake start`
5. Visit `localhost:9393`

## Tests

```
$ rake tests
```
