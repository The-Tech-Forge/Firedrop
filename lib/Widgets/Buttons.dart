import 'package:flutter/material.dart';

class Buttons {

  Widget submitButton({
    required VoidCallback onPressed,  
    required bool isLoading, 
    String buttonText = "Submit"
  }) {
    return SizedBox(
      width: double.infinity, 
      child: ElevatedButton(
        onPressed: onPressed,
        child: isLoading
            ? CircularProgressIndicator(
                color: Colors.white,
              )
            : Text(
                buttonText,
                style: TextStyle(color: Colors.white),
              ),
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 18.0), 
          backgroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0), 
          ),
        ),
      ),
    );
  }
}
