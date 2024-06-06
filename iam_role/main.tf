# エンジニアグループの作成
resource "aws_iam_group" "engineer_group" {
  name = "engineer_group"
}

# エンジニアグループにポリシーをアタッチ
resource "aws_iam_group_policy_attachment" "engineer_policy" {
  group      = aws_iam_group.engineer_group.name
  policy_arn = "arn:aws:iam::aws:policy/PowerUserAccess"
}

# ディレクターグループの作成
resource "aws_iam_group" "director_group" {
  name = "director_group"
}

# ディレクターグループにポリシーをアタッチ
resource "aws_iam_group_policy_attachment" "director_policy" {
  group      = aws_iam_group.director_group.name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

# ディレクターユーザーの作成
resource "aws_iam_user" "director_users" {
  for_each = var.directors
  name     = each.value
  path     = "/director/"
}

# ディレクターユーザーをディレクターグループに所属させる
resource "aws_iam_user_group_membership" "director_user_memberships" {
  for_each = var.directors
  user     = each.value
  groups   = ["director_group"]
}

# エンジニアユーザーの作成
resource "aws_iam_user" "engineer_users" {
  for_each = var.engineers
  name     = each.value
  path     = "/engineer/"
}

# エンジニアユーザーをエンジニアグループに所属させる
resource "aws_iam_user_group_membership" "engineer_user_memberships" {
  for_each = var.engineers
  user     = each.value
  groups   = ["engineer_group"]
}