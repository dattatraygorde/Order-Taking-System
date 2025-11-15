package com.example.ordertaking.controller;

import com.example.ordertaking.dto.VegetableSummary;
import com.example.ordertaking.entity.OrderHeader;
import com.example.ordertaking.entity.OrderItem;
import com.example.ordertaking.repository.CustomerRepository;
import com.example.ordertaking.repository.OrderItemRepository;
import com.example.ordertaking.repository.OrderRepository;
import com.example.ordertaking.repository.VegetableRepository;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

@Controller
@RequestMapping("/orders")
public class OrderController {

    private final CustomerRepository customerRepo;
    private final VegetableRepository vegetableRepo;
    private final OrderRepository orderRepo;
    private final OrderItemRepository orderItemRepo;

    public OrderController(CustomerRepository customerRepo,
                           VegetableRepository vegetableRepo,
                           OrderRepository orderRepo,
                           OrderItemRepository orderItemRepo) {
        this.customerRepo = customerRepo;
        this.vegetableRepo = vegetableRepo;
        this.orderRepo = orderRepo;
        this.orderItemRepo = orderItemRepo;
    }

    @GetMapping("/new")
    public String newOrder(Model model) {
        model.addAttribute("customers", customerRepo.findAll());
        model.addAttribute("vegetables", vegetableRepo.findAll());
        model.addAttribute("today", LocalDate.now());
        model.addAttribute("tab", "ordertaking");
        return "orders/new";
    }

    @PostMapping
    public String createOrder(
            @RequestParam("customerId") Long customerId,
            @RequestParam("orderDate") @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate orderDate,
            @RequestParam("vegetableIds") List<Long> vegetableIds,
            @RequestParam("quantities") List<Integer> quantities,
            Model model
    ) {
        if (vegetableIds == null || quantities == null || vegetableIds.isEmpty() || quantities.isEmpty() || vegetableIds.size() != quantities.size()) {
            model.addAttribute("error", "Please add at least one vegetable with quantity.");
            return "redirect:/orders/new";
        }

        var customer = customerRepo.findById(customerId).orElseThrow();
        var order = new OrderHeader(customer, orderDate);

        List<OrderItem> items = new ArrayList<>();
        for (int i = 0; i < vegetableIds.size(); i++) {
            var vegId = vegetableIds.get(i);
            var qty = quantities.get(i);
            if (qty == null || qty <= 0) continue;
            var veg = vegetableRepo.findById(vegId).orElseThrow();
            var item = new OrderItem(veg, qty, order);
            items.add(item);
            order.addItem(item);
        }

        if (order.getItems().isEmpty()) {
            model.addAttribute("error", "Please provide valid quantities.");
            return "redirect:/orders/new";
        }

        orderRepo.save(order);
        return "redirect:/orders/" + order.getId();
    }

    @GetMapping("/{id}")
    public String orderDetails(@PathVariable Long id, Model model) {
        var order = orderRepo.findById(id).orElseThrow();
        model.addAttribute("order", order);
        model.addAttribute("tab", "ordertaking");
        return "orders/confirm";
    }

    @GetMapping("/final")
    public String finalOrders(
            @RequestParam(value = "date", required = false)
            @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date,
            Model model
    ) {
        if (date == null) {
            date = LocalDate.now();
        }
        List<VegetableSummary> summary = orderItemRepo.summarizeByDate(date);
        model.addAttribute("date", date);
        model.addAttribute("summary", summary);
        model.addAttribute("orders", orderRepo.findByOrderDate(date));
        model.addAttribute("tab", "finalorders");
        return "orders/final";
    }
}