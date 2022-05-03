///[Login Exceptions]////

class WrongPasswordException implements Exception {
}

//invalid email exception
class InvalidEmailException implements Exception {
 
}


///[Register Exceptions]////
class  WeakPasswordException implements Exception {

}
  
class EmailAlreadyInUseException implements Exception {

}


class UserNotLoggedInException implements Exception {

}



class UserNotFoundException implements Exception {
  
}
//Genric exception
class GenricAuthException implements Exception {
 
}

class UnkownFirebaseAuthException implements Exception {
  
}



