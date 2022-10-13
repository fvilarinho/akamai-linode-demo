package br.com.demo.controller;

import br.com.demo.exceptions.PhonebookAlreadyExistsException;
import br.com.demo.model.Phonebook;

import java.util.List;
import java.util.Optional;

/**
 * Class that implements the validations of a phonebook.
 *
 * @author fvilarinho
 * @version 1.0.0
 */
public interface PhonebookValidator{
    //Check if the data exists in a list.
    static void exists(List<Phonebook> list, Integer id, String name) throws PhonebookAlreadyExistsException{
        if(id == null){
            if(list != null && !list.isEmpty())
                throw new PhonebookAlreadyExistsException();
        }
        else{
            if(list != null && !list.isEmpty()){
                Optional<Phonebook> result = list.stream().filter(i -> !i.getId().equals(id) && i.getName().equals(name)).findFirst();
            
                if(result.isPresent())
                    throw new PhonebookAlreadyExistsException();
            }
        }
    }
}
