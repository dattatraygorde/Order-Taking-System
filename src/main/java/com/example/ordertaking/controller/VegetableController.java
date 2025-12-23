package com.example.ordertaking.controller;

import com.example.ordertaking.entity.Vegetable;
import com.example.ordertaking.repository.VegetableRepository;
import javax.validation.Valid;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.*;

@Controller
@RequestMapping("/vegetables")
public class VegetableController {
    private final VegetableRepository vegetableRepo;

    public VegetableController(VegetableRepository vegetableRepo) {
        this.vegetableRepo = vegetableRepo;
    }

    @GetMapping
    public String list(Model model) {
        model.addAttribute("vegetables", vegetableRepo.findAll());
        model.addAttribute("tab", "vegetables");
        return "vegetables/list";
    }

    @GetMapping("/new")
    public String createForm(Model model) {
        model.addAttribute("vegetable", new Vegetable());
        model.addAttribute("tab", "vegetables");
        return "vegetables/form";
    }

    @PostMapping
    public String create(@Valid @ModelAttribute("vegetable") Vegetable vegetable, BindingResult result, Model model) {
        if (vegetableRepo.existsByNameIgnoreCase(vegetable.getName())) {
            result.rejectValue("name", "exists", "Vegetable already exists");
        }
        if (result.hasErrors()) {
            model.addAttribute("tab", "vegetables");
            return "vegetables/form";
        }
        vegetableRepo.save(vegetable);
        return "redirect:/vegetables";
    }

    @GetMapping("/{id}/edit")
    public String editForm(@PathVariable Long id, Model model) {
        var veg = vegetableRepo.findById(id).orElseThrow();
        model.addAttribute("vegetable", veg);
        model.addAttribute("tab", "vegetables");
        return "vegetables/form";
    }

    @PostMapping("/{id}/edit")
    public String update(@PathVariable Long id, @Valid @ModelAttribute("vegetable") Vegetable vegetable, BindingResult result, Model model) {
        var existing = vegetableRepo.findById(id).orElseThrow();
        if (!existing.getName().equalsIgnoreCase(vegetable.getName())
                && vegetableRepo.existsByNameIgnoreCase(vegetable.getName())) {
            result.rejectValue("name", "exists", "Vegetable already exists");
        }
        if (result.hasErrors()) {
            model.addAttribute("tab", "vegetables");
            return "vegetables/form";
        }
        vegetable.setId(id);
        vegetableRepo.save(vegetable);
        return "redirect:/vegetables";
    }

    @PostMapping("/{id}/delete")
    public String delete(@PathVariable Long id) {
        vegetableRepo.deleteById(id);
        return "redirect:/vegetables";
    }
}
