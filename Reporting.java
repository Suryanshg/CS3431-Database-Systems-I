import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Connection;
import java.sql.SQLException;
import java.util.Scanner;

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
    Scanner input = new Scanner(System.in);
    if (argv.length < 2 || argv.length > 3) {
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
      connection = DriverManager.getConnection("jdbc:oracle:thin:@csorcl.cs.wpi.edu:1521:orcl", argv[0], argv[1]);

    } catch (SQLException e) {
      System.out.println("Connection Failed! Check output console");
      e.printStackTrace();
      return;
    }

    if (connection != null)
      if (argv.length == 2) {
        System.out.println(
            "1- Report Patients Basic Information \n2- Reporting Doctors Basic Information \n3- Report Admissions Information\n4- Update Admissions Payment");
      } else {
        switch (argv[2]) {
          case "1":
            System.out.print("Enter Patient SSN:");
            String SSN = (input.nextLine());
            String Statement = "Select SSN,FirstName,LastName,Address From Patient Where SSN = " + "'" + SSN + "'";
            PreparedStatement pstmt = connection.prepareStatement(Statement);
            // pstmt.setString(1, "A");
            ResultSet Patient = pstmt.executeQuery();
            while (Patient.next()) {
              System.out.println("Patient SSN: " + Patient.getString("SSN"));
              System.out.println("Patient First Name: " + Patient.getString("FirstName"));
              System.out.println("Patient LastName: " + Patient.getString("LastName"));
              System.out.println("Patient Address: " + Patient.getString("Address"));
            }
            Patient.close();
            pstmt.close();
            break;
          case "2":
            System.out.print("Enter Doctor ID:");
            String DoctorID = input.nextLine();
            String DoctorStatement = ("Select ID,FirstName,LastName,gender From Doctor Where ID = " + "'" + DoctorID
                + "'");
            PreparedStatement pstmtDoc = connection.prepareStatement(DoctorStatement);
            // pstmt.setString(1, "A");
            ResultSet Doctor = pstmtDoc.executeQuery();
            while (Doctor.next()) {
              System.out.println("Doctor ID: " + Doctor.getString("ID"));
              System.out.println("Doctor First Name: " + Doctor.getString("FirstName"));
              System.out.println("Doctor LastName: " + Doctor.getString("LastName"));
              System.out.println("Doctor Gender: " + Doctor.getString("gender"));
            }
            break;
          case "3":
            System.out.print("Enter Admission Number:");
            Integer AdmissionNum = input.nextInt();
            String AdmissionStatement = ("Select Num,Patient_SSN,AdmissionDate,TotalPayment From Admission Where Num = ?");
            PreparedStatement pstmtAdmiss = connection.prepareStatement(AdmissionStatement);
            pstmtAdmiss.setInt(1, AdmissionNum);
            ResultSet AdmissionInfo = pstmtAdmiss.executeQuery();
            AdmissionInfo.next();
            System.out.println("Admission Number: " + AdmissionInfo.getString("Num"));
            System.out.println("Patient SSN: " + AdmissionInfo.getString("Patient_SSN"));
            System.out.println("Admission date(start date): " + AdmissionInfo.getString("AdmissionDate"));
            System.out.println("Total Payment: " + AdmissionInfo.getString("TotalPayment"));

            System.out.println("Rooms:");
            String RoomStatement = ("Select RoomNum,startDate,endDate From StayIn Where AdmissionNum = ?");
            PreparedStatement pstmtStayIn = connection.prepareStatement(RoomStatement);
            pstmtStayIn.setInt(1, AdmissionNum);
            ResultSet StayInInfo = pstmtStayIn.executeQuery();

            while (StayInInfo.next()) {
              System.out.println("\tRoomNum: " + StayInInfo.getString("RoomNum") + "\tFromDate: "
                  + StayInInfo.getString("startDate") + "\tEndDate: " + StayInInfo.getString("endDate"));
            }

            System.out.println("Doctors examined the patient in this admission:");
            String ExamineStatement = ("Select DISTINCT DoctorID From Examine Where AdmissionNum = ?");
            PreparedStatement pstmtExamine = connection.prepareStatement(ExamineStatement);
            pstmtExamine.setInt(1, AdmissionNum);
            ResultSet ExamineInfo = pstmtExamine.executeQuery();

            while (ExamineInfo.next()) {
              System.out.println("\tDoctor ID: " + ExamineInfo.getString("DoctorID"));
            }

            break;
          case "4":
            System.out.print("Enter Admission Number:");
            Integer AdmissionNumTwo = input.nextInt();
            System.out.print("Enter the new total payment:");
            Integer totalPayment = input.nextInt();
            String UpdatePaymentStatement = "UPDATE Admission set TotalPayment = ? Where Num = ?";
            PreparedStatement updatingTotalPayment = connection.prepareStatement(UpdatePaymentStatement);
            updatingTotalPayment.setInt(1, totalPayment);
            updatingTotalPayment.setInt(2, AdmissionNumTwo);
            Integer NumUpdated = updatingTotalPayment.executeUpdate();

            break;
        }
      }
    else {
      System.out.println("Failed to make connection!");
    }

    connection.close();
  }

}
