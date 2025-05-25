package com.invoice.backend.model;

import jakarta.persistence.*;
import lombok.Data;
import java.time.LocalDate;

@Data
@Entity
@Table(name = "invoice")
public class Invoice {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String invoiceNumber;   // 發票號碼
    private String storeName;       // 商店名稱
    private LocalDate date;         // 消費日期
    private Integer totalAmount;    // 金額（整數）
    private String items;           // 商品列表（文字串，可先簡化）

}

