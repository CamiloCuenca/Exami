package edu.uniquindio.exami.Controllers;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class FrontController {

    @GetMapping("/")
    public String mostrarInicio() {
        return "index"; // se refiere a index.html
    }

    @GetMapping("/login")
    public String mostrarLogin() {
        return "login"; // se refiere a login.html
    }

    // Puedes agregar más vistas según lo necesites
}
