package com.example.ordertaking.controller;

import com.example.ordertaking.entity.Customer;
import com.example.ordertaking.repository.CustomerRepository;
import javax.validation.Valid;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.*;

@Controller
@RequestMapping("/customers")
public class CustomerController {
    private final CustomerRepository customerRepo;

    public CustomerController(CustomerRepository customerRepo) {
        this.customerRepo = customerRepo;
    }

    @GetMapping
    public String list(Model model) {
        model.addAttribute("customers", customerRepo.findAll());
        model.addAttribute("tab", "customers");
        return "customers/list";
    }

    @GetMapping("/new")
    public String createForm(Model model) {
        model.addAttribute("customer", new Customer());
        model.addAttribute("tab", "customers");
        return "customers/form";
    }

    @PostMapping
    public String create(@Valid @ModelAttribute("customer") Customer customer, BindingResult result, Model model) {
        if (customerRepo.existsByEmail(customer.getEmail())) {
            result.rejectValue("email", "exists", "Email already exists");
        }
        if (result.hasErrors()) {
            model.addAttribute("tab", "customers");
            return "customers/form";
        }
        customerRepo.save(customer);
        return "redirect:/customers";
    }

    @GetMapping("/{id}/edit")
    public String editForm(@PathVariable Long id, Model model) {
        var customer = customerRepo.findById(id).orElseThrow();
        model.addAttribute("customer", customer);
        model.addAttribute("tab", "customers");
        return "customers/form";
    }

    @PostMapping("/{id}/edit")
    public String update(@PathVariable Long id, @Valid @ModelAttribute("customer") Customer customer, BindingResult result, Model model) {
        var existing = customerRepo.findById(id).orElseThrow();
        if (!existing.getEmail().equals(customer.getEmail()) && customerRepo.existsByEmail(customer.getEmail())) {
            result.rejectValue("email", "exists", "Email already exists");
        }
        if (result.hasErrors()) {
            model.addAttribute("tab", "customers");
            return "customers/form";
        }
        customer.setId(id);
        customerRepo.save(customer);
        return "redirect:/customers";
    }

    @PostMapping("/{id}/delete")
    public String delete(@PathVariable Long id) {
        customerRepo.deleteById(id);
        return "redirect:/customers";
    }
}
