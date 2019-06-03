# Security Analytics Platform - useful info

## Terraform tips

### Developing with modules

Throughout the project, when there is a `module` definition that includes some shared code, there are two lines at the start:

```
source = "github.com/...//..."
# source = "../../..."
```

If you are developing the code linked to in source, then you should comment out the first line, and uncomment the second - so that you are not pulling old code from github.

Before checking in your code, swap the comments around again.

For github, there are two slashes as part of the URI - this is intentional and [described here](https://www.terraform.io/docs/modules/sources.html#modules-in-package-sub-directories)

## Code structure


## Testing code
