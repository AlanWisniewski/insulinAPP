# insulinapp

This project, developed using the Flutter framework, involves the implementation of a mobile application to assist diabetics in managing their condition. It was created as part of an engineering thesis at university. The application is still in the early stages of development, and its documentation (which is essentially the engineering thesis) is available upon request.
## Features

Homepage consists of basic informations about insulin dosages, and provides two buttons to measure certain health parameters.

![image](https://github.com/AlanWisniewski/insulinAPP/assets/37334261/a883a21f-ab5e-4bbb-9bab-e4ce80d1fc13)

![image](https://github.com/AlanWisniewski/insulinAPP/assets/37334261/53d4a52b-f7ae-43eb-bdca-a3de0f56f55e)
![image](https://github.com/AlanWisniewski/insulinAPP/assets/37334261/d73cbba4-aca2-43fe-ba03-560062b4c3df)

The search button redirects us to a page where you can find particular foods and add them to a calculation

![image](https://github.com/AlanWisniewski/insulinAPP/assets/37334261/a14b0239-17ff-4cba-8684-43b50e87e719)
![image](https://github.com/AlanWisniewski/insulinAPP/assets/37334261/db3da9a9-a990-4a7e-b580-fc3aa1544743)

By clicking the "plus" button, you can add a desired product to the database

![image](https://github.com/AlanWisniewski/insulinAPP/assets/37334261/a4749af2-51da-40a4-a231-adba86f1cf53)

The "diary" button lets you summarize the food added to it, change it if needed and finally calculate a dosage of insulin needed for that particular dish

![image](https://github.com/user-attachments/assets/c61ba6a2-ca59-4a6e-98e9-fbfe723aa30c)
![image](https://github.com/AlanWisniewski/insulinAPP/assets/37334261/80d6c857-98d9-492f-a39b-050853cd5dc9)

The last page allows you to configure settings for more precise calculations performed by the application

![image](https://github.com/AlanWisniewski/insulinAPP/assets/37334261/f802f179-e737-4eb1-8a18-619d8b5f5815)

The application retrieves data about food from a CSV file and then transfers it to a database table, which also stores user-added dishes.
Below is the structure of the "food" table:

![image](https://github.com/AlanWisniewski/insulinAPP/assets/37334261/eab6f256-6719-43e0-8add-9518a75c5a62)

The database also stores user settings and bolus data. Everything works under sqflite package.

