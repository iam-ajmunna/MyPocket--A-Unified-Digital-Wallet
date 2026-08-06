# Feature: Release Preparation & Store Publishing Documentation

## Purpose
Release preparation documentation for MyPocket v1.0.0, including Play Store Data Safety disclosures, Apple App Store privacy manifest, Docker production deployment configuration, and CHANGELOG finalization.

## Scope (v1)
- **Production Containerization**: Dockerfile & docker-compose for NestJS + PostgreSQL deployment.
- **Privacy Policy & Data Safety Disclosures**:
  - Declaration of AES-256-GCM encryption in transit and at rest.
  - Disclosure of optional features (biometrics, speech recognition, camera scan).
  - Clarification that full NID/Passport/CVV values are never collected or shared with third parties.
- **GitFlow Release Branch**: Cut `release/1.0.0` per AGENTS.md Section 6.
- **CHANGELOG.md**: Finalized v1.0.0 release notes.

## Status
Complete — 2026-08-06
