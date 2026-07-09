# cdb-metadata

Terraform configuration for the control-plane metadata store used by CDB. Provisions the DynamoDB tables that back user accounts, chronicles, views, replicas, and the read/write schemas associated with them.

## Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/downloads) (compatible with the `hashicorp/aws` provider)
- AWS credentials with permission to create/manage DynamoDB tables, configured via the standard AWS credential chain (environment variables, `~/.aws/credentials`, etc.)

## Usage

```bash
terraform init
terraform plan -var="region=us-east-1"
terraform apply -var="region=us-east-1"
```

The `region` variable is required and has no default — pass it via `-var`, a `.tfvars` file, or the `TF_VAR_region` environment variable.

## Resources

All tables use `PAY_PER_REQUEST` billing mode.

| Table | Partition Key | Sort Key | GSIs |
|---|---|---|---|
| `users` | `id` | — | `users-by-hashed-api-key` (hash: `hashedApiKey`) |
| `chronicles` | `userId` | `name` | — |
| `replicas` | `id` | — | `replicas-by-status` (hash: `status`) |
| `views` | `userId` | `chronicleNameViewName` | `id-index` (hash: `id`) |
| `associations` | `viewId` | `replicaId` | `replicaId-index` (hash: `replicaId`) |
| `write_schemas` | `id` | — | `userId-chronicleName-index` (hash: `userId`, range: `chronicleName`) |
| `read_schemas` | `id` | — | — |

### Notes on key design

- **`chronicles`** uses a composite key (`userId` + `name`) to enforce that chronicle names are unique per user.
- **`views`** uses a composite key (`userId` + `chronicleNameViewName`) to enforce that view names are unique per user and chronicle, with a separate `id-index` GSI for lookups by view ID alone.
- **`associations`** links replicas to views via a composite key (`viewId` + `replicaId`), enforcing one association per replica/view pair, with a `replicaId-index` GSI for reverse lookups.

## Outputs

Each table exposes its name and ARN as outputs (e.g. `users_table_name`, `users_table_arn`), intended for consumption by other services or Terraform configurations that depend on this metadata store.