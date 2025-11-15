package com.example.ordertaking.config;

import com.example.ordertaking.entity.Customer;
import com.example.ordertaking.entity.Vegetable;
import com.example.ordertaking.repository.CustomerRepository;
import com.example.ordertaking.repository.VegetableRepository;
import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Configuration;

@Configuration
public class DataLoader implements CommandLineRunner {

    private final CustomerRepository customerRepository;
    private final VegetableRepository vegetableRepository;

    public DataLoader(CustomerRepository customerRepository, VegetableRepository vegetableRepository) {
        this.customerRepository = customerRepository;
        this.vegetableRepository = vegetableRepository;
    }

    @Override
    public void run(String... args) throws Exception {
        if (customerRepository.count() == 0) {
            Customer c1 = new Customer();
            c1.setFirstName("John");
            c1.setLastName("Doe");
            c1.setEmail("john.doe@example.com");
            c1.setAddress("123 Main St, City");
            customerRepository.save(c1);

            Customer c2 = new Customer();
            c2.setFirstName("Jane");
            c2.setLastName("Smith");
            c2.setEmail("jane.smith@example.com");
            c2.setAddress("456 Market Rd, Town");
            customerRepository.save(c2);
        }

        if (vegetableRepository.count() == 0) {
            vegetableRepository.save(new Vegetable("Tomato"));
            vegetableRepository.save(new Vegetable("Potato"));
            vegetableRepository.save(new Vegetable("Onion"));
            vegetableRepository.save(new Vegetable("Cucumber"));
        }
    }
}