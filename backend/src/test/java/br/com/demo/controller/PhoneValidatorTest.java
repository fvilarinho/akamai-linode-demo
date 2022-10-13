package br.com.demo.controller;

import br.com.demo.exceptions.PhonebookAlreadyExistsException;
import br.com.demo.helpers.Mocks;
import br.com.demo.model.Phonebook;
import org.junit.jupiter.api.Assertions;
import org.junit.jupiter.api.Test;

import java.util.Collections;
import java.util.List;

/**
 * Unit test class for the phonebook validation.
 *
 * @author fvilarinho
 */
class PhoneValidatorTest{
    private List<Phonebook> mockList = Mocks.getList();

    //Check if the data exists in a list.
    @Test
    void exists(){
        try{
            PhonebookValidator.exists(null, 1, "Luke Skywalker");
    
            Assertions.assertTrue(true);
        }
        catch(PhonebookAlreadyExistsException e){
            Assertions.assertTrue(false);
        }

        try{
            PhonebookValidator.exists(Collections.EMPTY_LIST, 1, "Luke Skywalker");

            Assertions.assertTrue(true);
        }
        catch(PhonebookAlreadyExistsException e){
            Assertions.assertTrue(false);
        }
    
        try{
            PhonebookValidator.exists(mockList, 2, "Luke Skywalker");
        
            Assertions.assertTrue(true);
        }
        catch(PhonebookAlreadyExistsException e){
            Assertions.assertTrue(true);
        }
    
        try{
            PhonebookValidator.exists(mockList, 2, "Yoda");
        
            Assertions.assertTrue(true);
        }
        catch(PhonebookAlreadyExistsException e){
            Assertions.assertTrue(true);
        }
    
        try{
            PhonebookValidator.exists(mockList, 1, "Yoda");
        
            Assertions.assertTrue(true);
        }
        catch(PhonebookAlreadyExistsException e){
            Assertions.assertTrue(true);
        }
    }
}