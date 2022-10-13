package br.com.demo.controller;

import br.com.demo.exceptions.PhonebookNotFoundException;
import br.com.demo.helpers.Mocks;
import br.com.demo.model.Phonebook;
import br.com.demo.service.PhonebookService;
import org.hamcrest.Matchers;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mockito;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.test.context.junit.jupiter.SpringExtension;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders;
import org.springframework.test.web.servlet.result.MockMvcResultMatchers;

import java.util.Collections;
import java.util.List;

/**
 * Integration test class for the controller.
 *
 * @author fvilarinho@gmail.com
 */
@ExtendWith(SpringExtension.class)
@WebMvcTest(controllers = Controller.class)
class ControllerTest{
    @Autowired
    private MockMvc mockMvc;
    
    @MockBean
    private PhonebookService mockService;
    
    private List<Phonebook> mockList = Mocks.getList();
    private Phonebook mockItem = Mocks.getItem();
    
    // Test the search requests.
    @Test
    void search() throws Exception{
        String q = "Luke";
        
        Mockito.when(mockService.findByNameContaining(q)).thenReturn(mockList);
        Mockito.when(mockService.findByNameContaining("")).thenReturn(mockList);
    
        mockMvc.perform(MockMvcRequestBuilders.post("/search").param("q", q)).andExpect(MockMvcResultMatchers.status().isOk()).andExpect(MockMvcResultMatchers.model().attribute("result", mockList));
        mockMvc.perform(MockMvcRequestBuilders.post("/search")).andExpect(MockMvcResultMatchers.status().isOk()).andExpect(MockMvcResultMatchers.model().attribute("result", mockList));
    }
    
    // Test the add requests.
    @Test
    void add() throws Exception{
        mockMvc.perform(MockMvcRequestBuilders.post("/add")).andExpect(MockMvcResultMatchers.status().isOk()).andExpect(MockMvcResultMatchers.model().attribute("id", Matchers.nullValue())).andExpect(MockMvcResultMatchers.model().attribute("name", Matchers.nullValue())).andExpect(MockMvcResultMatchers.model().attribute("phone", Matchers.nullValue()));
    }
    
    // Test the edit requests for existing items.
    @Test
    void editExistingItem() throws Exception{
        Mockito.when(mockService.findById(mockItem.getId())).thenReturn(mockItem);
    
        mockMvc.perform(MockMvcRequestBuilders.post("/edit").param("id", mockItem.getId().toString())).andExpect(MockMvcResultMatchers.status().isOk()).andExpect(MockMvcResultMatchers.model().attribute("id", mockItem.getId())).andExpect(MockMvcResultMatchers.model().attribute("name", mockItem.getName())).andExpect(MockMvcResultMatchers.model().attribute("phone", mockItem.getPhone()));
    }
    
    // Test the edit requests for not found items.
    @Test
    void editNotFoundItem() throws Exception{
        Mockito.when(mockService.findById(mockItem.getId())).thenThrow(PhonebookNotFoundException.class);
    
        mockMvc.perform(MockMvcRequestBuilders.post("/edit").param("id", mockItem.getId().toString())).andExpect(MockMvcResultMatchers.status().isOk()).andExpect(MockMvcResultMatchers.model().attribute("message", Matchers.any(String.class)));
    }
    
    // Test the save requests for existing items.
    @Test
    void saveExistingItem() throws Exception{
        Mockito.when(mockService.findByNameContaining("")).thenReturn(mockList);
    
        mockMvc.perform(MockMvcRequestBuilders.post("/save").param("id", mockItem.getId().toString()).param("name", mockItem.getName().toString()).param("phone", mockItem.getPhone().toString())).andExpect(MockMvcResultMatchers.status().isOk()).andExpect(MockMvcResultMatchers.model().attribute("result", mockList));
    
        Mockito.when(mockService.findByName(mockItem.getName())).thenReturn(mockList);
    
        mockMvc.perform(MockMvcRequestBuilders.post("/save").param("name", mockItem.getName()).param("phone", mockItem.getPhone())).andExpect(MockMvcResultMatchers.status().isOk()).andExpect(MockMvcResultMatchers.model().attribute("nameMessage", Matchers.any(String.class)));
    }
    
    // Test the save requests for new items.
    @Test
    void saveNewItem() throws Exception{
        Mockito.when(mockService.findByNameContaining("")).thenReturn(mockList);
        Mockito.when(mockService.findByName(mockItem.getName())).thenReturn(Collections.EMPTY_LIST);
    
        mockMvc.perform(MockMvcRequestBuilders.post("/save").param("name", mockItem.getName().toString()).param("phone", mockItem.getPhone().toString())).andExpect(MockMvcResultMatchers.status().isOk()).andExpect(MockMvcResultMatchers.model().attribute("result", mockList));
    
        Mockito.when(mockService.findByName(mockItem.getName())).thenReturn(null);
    
        mockMvc.perform(MockMvcRequestBuilders.post("/save").param("name", mockItem.getName().toString()).param("phone", mockItem.getPhone().toString())).andExpect(MockMvcResultMatchers.status().isOk()).andExpect(MockMvcResultMatchers.model().attribute("result", mockList));
    }
    
    // Test the save requests for invalid items.
    @Test
    void saveInvalidItem() throws Exception{
        mockMvc.perform(MockMvcRequestBuilders.post("/save").param("name", "").param("phone", "")).andExpect(MockMvcResultMatchers.status().isOk()).andExpect(MockMvcResultMatchers.model().attribute("nameMessage", Matchers.any(String.class))).andExpect(MockMvcResultMatchers.model().attribute("phoneMessage", Matchers.any(String.class)));
    }
    
    // Test the delete requests.
    @Test
    void delete() throws Exception{
        Mockito.when(mockService.findByNameContaining("")).thenReturn(null);
        Mockito.when(mockService.findById(mockItem.getId())).thenReturn(mockItem);
    
        mockMvc.perform(MockMvcRequestBuilders.post("/delete").param("id", mockItem.getId().toString())).andExpect(MockMvcResultMatchers.status().isOk()).andExpect(MockMvcResultMatchers.model().attribute("result", Matchers.nullValue()));
    }
    
    // Test the log requests for valid data.
    @Test
    void logValidData() throws Exception{
        mockMvc.perform(MockMvcRequestBuilders.post("/log").content("{\"name\": \"Luke Skywalker\"}")).andExpect(MockMvcResultMatchers.status().isOk());
    }
    
    // Test the log requests for invalid data.
    @Test
    void logInvalidData() throws Exception{
        mockMvc.perform(MockMvcRequestBuilders.post("/log").content("{'name': 'Luke Skywalker'}")).andExpect(MockMvcResultMatchers.status().is5xxServerError());
    }
}
