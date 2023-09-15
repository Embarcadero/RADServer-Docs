## Chapter 3: Creating your first CRUD Application

Don't forget to [watch the video](https://youtu.be/ud3KFTq7vr8) of this chapter. 

RAD Studio provides multiple ready to use components but one of the most useful ones when it comes to create CRUD APIs is **EMSDataSetResource**. This component allows you to link a FireDAC query to it and expose not only the data but also manipulate it. The component creates automatically all the required endpoints for CRUD and provides extra functionality like pagination, sorting and more. 

The **EMSDataSetResource** can be created in any of your current units, or even easier, use the RAD Server Wizard to create all the required components automatically linked to a FDConnection. 

### Steps before running the demo

To configure the demo included in this chapter correctly you will find the **employee.gdb** database in the folder **resources** in the root path of this repository. You just need to add it as one of your available databases in the **Data Explorer** tab and name it **employee**. Another option is modifying the **FDConnection** component to point to the database. Remember you will need **InterBase** dev installed in your machine.

