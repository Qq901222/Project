package com.invoice.backend.controller;

import com.invoice.backend.model.Invoice;
import com.invoice.backend.repository.InvoiceRepository;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/invoices")
public class InvoiceController {

    private final InvoiceRepository repository;

    public InvoiceController(InvoiceRepository repository) {
        this.repository = repository;
    }

    @GetMapping
    public List<Invoice> getAll() {
        return repository.findAll();
    }

    @PostMapping
    public Invoice add(@RequestBody Invoice invoice) {
        return repository.save(invoice);
    }
}
