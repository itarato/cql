CQL
---

![Logo](assets/cql_logo_small.png)

Code Query Language is a command line semantic code search tool for Ruby. This is not a replacement to Grep as it so

## Install:

```bash
gem install cql
```

## Usage:

```
cql PATTERN PATH
```

`cql --help` for more info.

## Filters:

### Type

Comma separated list of (parent node) types.

Example:

`cql foo ./ type:send,arg`

Available types: https://github.com/whitequark/parser/blob/master/lib/parser/meta.rb#L11-L34
 
### Nesting

Under what structure the subject is nested.

Example:

`cql foo ./ nest:class=User`

Accepted nest structures: class, module, def, block
