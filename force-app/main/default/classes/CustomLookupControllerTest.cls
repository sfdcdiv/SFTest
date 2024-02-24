@istest
public class CustomLookupControllerTest {
      private static testMethod void testMethodOne() {
      Account acc = new Account();
      acc.Name = 'test';
      acc.Phone = '1234567897';
      insert acc;
              
     Test.startTest();
     List<Account> accnew1 = CustomLookupController.search('test', 'Account','Phone !=null');
     List<Account> accnew2 = CustomLookupController.search('test', 'Account','');
     List<Account> accnew3 = CustomLookupController.search('', 'Account','');
     Test.stopTest();
  }
 
}