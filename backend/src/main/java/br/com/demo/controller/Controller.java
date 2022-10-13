package br.com.demo.controller;

import br.com.demo.exceptions.PhonebookAlreadyExistsException;
import br.com.demo.exceptions.PhonebookNotFoundException;
import br.com.demo.model.Phonebook;
import br.com.demo.service.PhonebookService;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.ui.Model;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestParam;

import javax.servlet.http.HttpServletRequest;
import javax.validation.constraints.NotBlank;
import javax.validation.constraints.NotNull;
import java.io.IOException;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Class that defines the controller of the UI requests.
 *
 * @author fvilarinho
 * @version 1.0.0
 */
@org.springframework.stereotype.Controller
@Validated
public class Controller{
    private static final ObjectMapper mapper = new ObjectMapper();
    private static final Logger logger = Logger.getLogger(Controller.class.getName());
    
    @Autowired
    private PhonebookService service;
    
    // Endpoint for search data.
    @PostMapping("/search")
    public void search(Model model,
                       @RequestParam(value = "q", required = false) String q){
        model.addAttribute("q", q);
        
        if(q == null)
            q = "";
            
        model.addAttribute("result", service.findByNameContaining(q));
    }
    
    // Endpoint to save (new or existent) data.
    @PostMapping("/save")
    public String save(Model model,
                       HttpServletRequest request,
                     @RequestParam(value = "q", required = false) String q,
                     @RequestParam(value = "id", required = false) Integer id,
                     @RequestParam(value = "name", required = true) @NotNull @NotBlank(message = "Name is mandatory") String name,
                     @RequestParam(value = "phone", required = true) @NotNull @NotBlank(message = "Phone is mandatory") String phone) throws PhonebookAlreadyExistsException, PhonebookNotFoundException{
        List<Phonebook> list = service.findByName(name);
        
        PhonebookValidator.exists(list, id, name);

        Phonebook phonebook = new Phonebook();
        
        phonebook.setId(id);
        phonebook.setName(name);
        phonebook.setPhone(phone);
    
        service.save(phonebook);
    
        search(model, q);
        
        return "search";
    }
   
    // Endpoint to delete data.
    @PostMapping("/delete")
    public String delete(Model model,
                         HttpServletRequest request,
                       @RequestParam(value = "q", required = false) String q,
                       @RequestParam(value = "id", required = true) Integer id) throws PhonebookNotFoundException{
        Phonebook phonebook = service.findById(id);
    
        service.delete(phonebook);
        
        search(model, q);
        
        return "search";
    }
    
    // Endpoint to add a new data.
    @PostMapping("/add")
    public String add(Model model){
        model.addAttribute("id", null);
        model.addAttribute("name", null);
        model.addAttribute("phone", null);

        return "form";
    }
    
    // Endpoint to edit an existing data.
    @PostMapping("/edit")
    public String edit(Model model,
                       HttpServletRequest request,
                       @RequestParam(value = "q", required = false) String q,
                       @RequestParam(value = "id", required = true) Integer id) throws PhonebookNotFoundException{
        Phonebook phonebook = service.findById(id);

        model.addAttribute("id", phonebook.getId());
        model.addAttribute("name", phonebook.getName());
        model.addAttribute("phone", phonebook.getPhone());

        return "form";
    }
    
    // Endpoint to log data.
    @PostMapping("/log")
    public String log(@RequestBody String body){
        try{
            Object object = mapper.readValue(body, Object.class);
            
            logger.log(Level.INFO, "{0}", mapper.writerWithDefaultPrettyPrinter().writeValueAsString(object));
        }
        catch(IOException e){
            logger.log(Level.SEVERE, "Something wrong happened: {0}, ", e.getMessage());
            
            throw new IllegalArgumentException();
        }
    
        return "blank";
    }
}
