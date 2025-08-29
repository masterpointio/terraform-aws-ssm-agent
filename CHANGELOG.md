# Changelog

## [1.7.0](https://github.com/masterpointio/terraform-aws-ssm-agent/compare/v1.6.0...v1.7.0) (2025-08-29)


### Features

* add VPC and subnet name support ([#54](https://github.com/masterpointio/terraform-aws-ssm-agent/issues/54)) ([8a3d43c](https://github.com/masterpointio/terraform-aws-ssm-agent/commit/8a3d43c7b239ffc24e9083953bc30e5bcce6e027))

## [1.6.0](https://github.com/masterpointio/terraform-aws-ssm-agent/compare/v1.5.0...v1.6.0) (2025-08-28)


### Features

* allow additional custom IAM policy to attached EC2 role ([#52](https://github.com/masterpointio/terraform-aws-ssm-agent/issues/52)) ([93a7757](https://github.com/masterpointio/terraform-aws-ssm-agent/commit/93a77571a32dab45310d247f20f3e3d75d94e86d))

## [1.5.0](https://github.com/masterpointio/terraform-aws-ssm-agent/compare/v1.4.0...v1.5.0) (2025-08-01)


### Features

* fix deprecation warning ([#47](https://github.com/masterpointio/terraform-aws-ssm-agent/issues/47)) ([dbd82ca](https://github.com/masterpointio/terraform-aws-ssm-agent/commit/dbd82ca66426b6d8ec44c39b442a32a464ed5844))


### Bug Fixes

* auto-detect the root device name from the AMI ([#43](https://github.com/masterpointio/terraform-aws-ssm-agent/issues/43)) ([f8a5316](https://github.com/masterpointio/terraform-aws-ssm-agent/commit/f8a531670ce97f7a98f64a03de4663ace189a7c9))

## [1.4.0](https://github.com/masterpointio/terraform-aws-ssm-agent/compare/v1.3.0...v1.4.0) (2025-05-15)


### Features

* allow configuring of additional security group rules ([#38](https://github.com/masterpointio/terraform-aws-ssm-agent/issues/38)) ([5f9e32d](https://github.com/masterpointio/terraform-aws-ssm-agent/commit/5f9e32deeaf207b4ebf7a8a7a924cf132d3fb44a))


### Bug Fixes

* **gha:** tf test pr target ([#40](https://github.com/masterpointio/terraform-aws-ssm-agent/issues/40)) ([5a2e766](https://github.com/masterpointio/terraform-aws-ssm-agent/commit/5a2e766f9c92f096aa81ca35e22e5b22e80a7230))

## [1.3.0](https://github.com/masterpointio/terraform-aws-ssm-agent/compare/1.2.1...v1.3.0) (2025-01-04)


### Features

* clean up test and test actual logic ([60e09ea](https://github.com/masterpointio/terraform-aws-ssm-agent/commit/60e09eaea366e06809b805cb22dcaa523d8e9d88))
* filter the most recent AMIs ([3b26671](https://github.com/masterpointio/terraform-aws-ssm-agent/commit/3b266719e574bf1e427c74ba31bb7aed1658c68a))
* integration tests with native framework ([04f7d2f](https://github.com/masterpointio/terraform-aws-ssm-agent/commit/04f7d2f4060035a21a8ccdffa3b75dc6817b9fbb))
* lookup for AMI that doesn't contain ECS/EKS agent and packages + enable setting volume size ([#30](https://github.com/masterpointio/terraform-aws-ssm-agent/issues/30)) ([27f1d8a](https://github.com/masterpointio/terraform-aws-ssm-agent/commit/27f1d8a37ee52d704c85b282ef5a9e5af4ff83b1))


### Bug Fixes

* place GHA files to correct dir ([#31](https://github.com/masterpointio/terraform-aws-ssm-agent/issues/31)) ([1855c7e](https://github.com/masterpointio/terraform-aws-ssm-agent/commit/1855c7ea4af8bec22e7eb3439ea7bd772cb87c54))
