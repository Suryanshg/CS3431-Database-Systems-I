import java.sql.DriverManager;
import java.sql.Connection;
import java.sql.SQLException;


/* ++++++++++++++++++++++++++++++++++++++++++++++
  Make sure you did the following before execution
     1) Log in to CCC machine using your WPI account

     2) Set environment variables using the following command
       > source /cs/bin/oracle-setup

     3- Set CLASSPATH for java using the following command
       > export CLASSPATH=./:/usr/lib/oracle/18.5/client64/lib/ojdbc8.jar

     4- Write your java code (say file name is OracleTest.java) and then compile it using the  following command
       > /usr/local/bin/javac OracleTest.java

     5- Run it
        > /usr/local/bin/java OracleTest
  ++++++++++++++++++++++++++++++++++++++++++++++  */


public class Reporting {

    public static void main(String[] argv) throws SQLException {
      if (argv.length<2 || argv.length>3 )
      {
        System.out.println("Incorrect Number of Arguments");
        return;
      }
        try {
		Class.forName("oracle.jdbc.driver.OracleDriver");
        } catch (ClassNotFoundException e) {
            e.printStackTrace();
            return;
        }


        Connection connection = null;
        try {
            connection = DriverManager.getConnection(
                                                     "jdbc:oracle:thin:@csorcl.cs.wpi.edu:1521:orcl", argv[0],
                                                     argv[1]);
                              

        } catch (SQLException e) {
            System.out.println("Connection Failed! Check output console");
            e.printStackTrace();
            return;
        }

        if (connection != null) 
        if(argv.length=2)
        {System.out.println("1- Report Patients Basic Information
                            \n2- Reporting Doctors Basic Information
                            \n3- Report Admissions Information
                            \n 4- Update Admissions Payment");
                            }
        else{
          switch (argv[2]){
          case 1: 
            break;
          case 2:
            break;
          case 3:
            break;
          case 4:
            break;
          }
        } 
        else {
            System.out.println("Failed to make connection!");
        }
        
        connection.close();
    }

}
