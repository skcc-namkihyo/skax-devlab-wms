package com.execnt.config;

import io.swagger.v3.oas.models.Components;
import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Contact;
import io.swagger.v3.oas.models.info.Info;
import io.swagger.v3.oas.models.media.ObjectSchema;
import io.swagger.v3.oas.models.security.SecurityRequirement;
import io.swagger.v3.oas.models.security.SecurityScheme;
import io.swagger.v3.oas.models.servers.Server;
import org.springdoc.core.utils.SpringDocUtils;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import java.util.List;
import java.util.Map;

@Configuration
public class SwaggerConfig {

    static {
        try {
            SpringDocUtils.getConfig().replaceWithSchema(Map.class, new ObjectSchema());
            SpringDocUtils.getConfig().replaceWithSchema(java.util.HashMap.class, new ObjectSchema());
            SpringDocUtils.getConfig().replaceWithSchema(java.util.LinkedHashMap.class, new ObjectSchema());
        } catch (Exception e) {
            System.err.println("Swagger Map 스키마 설정 실패: " + e.getMessage());
        }
    }

    @Bean
    public OpenAPI customOpenAPI() {
        final String securitySchemeName = "bearerAuth";
        return new OpenAPI()
                .info(new Info()
                        .title("WMS REST API")
                        .version("1.0.0")
                        .description("WMS 교육 프로젝트 API")
                        .contact(new Contact().name("WMS Team")))
                .servers(List.of(new Server().url("http://localhost:8080").description("로컬")))
                .addSecurityItem(new SecurityRequirement().addList(securitySchemeName))
                .components(new Components()
                        .addSecuritySchemes(securitySchemeName,
                                new SecurityScheme()
                                        .name(securitySchemeName)
                                        .type(SecurityScheme.Type.HTTP)
                                        .scheme("bearer")
                                        .bearerFormat("JWT")));
    }
}
