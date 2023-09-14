## Chapter 10: RAD Server Lite

Don't forget to [watch the video](https://youtube.com/) of this chapter. 

**RAD Server Lite** (RSLite) offers a simpler deployment model for test servers and scenarios not requiring a lot of throughputs, and it offers this by using the InterBase embedded database engine, **IBToGo**, instead of the full-blown server and combines it with a simplified licensing model.

RSLite uses the same binary of the development edition (that ships with RAD Studio) along with IBToGo binaries and a license slip file you can deploy with your solution (requiring no registration on the computer you deploy it to). Because it uses an embedded database and because it uses the Indy HTTP Server component, it cannot serve the same number of requests per second of a regular full-blown RAD Server installation, and it cannot scale with multiple RAD Server front ends.



