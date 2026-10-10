package com.example.demo.controller;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class WelcomeController {

    @Value("${spring.profiles.active:dev}")
    private String activeProfile;

    @GetMapping("/")
    public String welcome(Model model) {
        model.addAttribute("name", "刘翔");
        model.addAttribute("env", activeProfile);
        return "welcome";
    }
}
