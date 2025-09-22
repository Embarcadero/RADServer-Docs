## Chapter 17: Mapping Endpoints to External Classes

This feature allows RAD Server custom resources to delegate request processing to resource module fields that implement the `IEMSEndpointPublisher` interface. With this capability, you can organize your API endpoints into logical groups using custom publisher classes.

The demo showcases how to create and configure custom endpoint publishers in RAD Server, demonstrating resource naming conventions and the attribute priority system for endpoint configuration.

> [!IMPORTANT]
> Due to the fact that this demo heavily relies on RTTI, it's only available for Delphi. 