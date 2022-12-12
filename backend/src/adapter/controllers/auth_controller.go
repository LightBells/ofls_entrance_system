package controllers

import (
	"fmt"
	"github.com/ken109/gin-jwt"

	"github.com/LightBells/ofls_entrance_system/src/adapter/interfaces"
)

type AuthController struct {
}

func NewAuthController() *AuthController {
	return &AuthController{}
}

func (ac *AuthController) Login(c interfaces.Context, config interfaces.Config) {
	type User struct {
		ID       string `json:"id"`
		Password string `json:"password"`
	}
	type Credentials struct {
		User User `json:"user"`
	}

	var credentials Credentials
	if err := c.ShouldBindJSON(&credentials); err != nil {
		c.JSON(400, NewError(400, "Malformed JSON"))
		return
	}

	fmt.Println(credentials)

	if credentials.User.ID != "admin" || credentials.User.Password != config.GetAdminPassword() {
		c.JSON(401, NewError(401, "invalid id or password"))
		return
	}

	type Response struct {
		Token        string `json:"token"`
		RefreshToken string `json:"refresh_token"`
	}

	token, refreshToken, err := jwt.IssueToken(
		config.GetJWTRealm(),
		jwt.Claims{
			"admin": true,
		},
	)

	if err != nil {
		c.JSON(500, NewError(500, "failed to issue token"))
		return
	}

	response := Response{
		Token:        token,
		RefreshToken: refreshToken,
	}

	c.JSON(200, response)
}

func (ac *AuthController) Refresh(c interfaces.Context, config interfaces.Config) {
	refreshToken := c.PostForm("refresh_token")

	ok, token, refreshToken, err := jwt.RefreshToken(
		config.GetJWTRealm(),
		refreshToken,
	)
	if !ok {
		c.Status(401)
		return
	}

	if err != nil {
		c.JSON(401, NewError(401, "invalid refresh token"))
		return
	}

	type Response struct {
		Token        string `json:"token"`
		RefreshToken string `json:"refresh_token"`
	}

	response := Response{
		Token: token,
	}

	c.JSON(200, response)
}
