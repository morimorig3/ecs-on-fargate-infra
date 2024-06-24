# -----------------------------------------
# Director ユーザーの作成
# -----------------------------------------

variable "directors" {
  type = map(string)
  default = {
    "user1" = "User1",
    "user2" = "User2",
    // 以下、他のユーザー
  }
}


# -----------------------------------------
# Engineer ユーザーの作成
# -----------------------------------------

variable "engineers" {
  type = map(string)
  default = {
    "user1" = "User1",
    "user2" = "User2",
    // 以下、他のユーザー
  }
}
