## Chapter 6: JSONValue, JSONWriter and JSON builder

Don't forget to [watch the video](https://youtube.com/) of this chapter. 

RAD Server provides support for handling JSON data that can be consumed by different programming languages and tools. Creating a JSON string, transmitting the string as a response, and having the client application code process the return is okay for smaller amounts of data. Imagine how large a JSON array response would be for an entire database or a complex data structure? RAD Studio provides three main frameworks for working with JSON data. This chapter covers a few of the many ways RAD Server applications can return JSON to a calling application.

### Frameworks for Handling JSON Data

RAD Studio provides multiple frameworks to handle JSON data. The three most common are:
- JSON Objects Framework – creates temporary objects to read and write JSON data.
- Readers and Writers JSON Framework – allows you to read and write JSON data directly.
- JSONBuilder – using writers, create complex structures in a more maintainable way.

In the demo files you'll find different examples of using this set of frameworks. 
