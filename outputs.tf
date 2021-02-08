output "alb_endpoint" {
  description = "The ALB endpoint you should use to check apache."
  value       = module.awesome_challenge_alb.alb_dns_name
}
