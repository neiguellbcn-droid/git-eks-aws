# 1. Límite de seguridad en tu Auto Scaling Group
resource "aws_autoscaling_group" "Nodos" {
  name                = "eks-nodos-asg"
  min_size            = 1
  max_size            = 5  # Freno máximo de instancias
  desired_capacity    = 2
  vpc_zone_identifier = ["module.vpc.private_subnets[0]", "module.vpc.private_subnets[1]"]

  launch_template {
    id      = "lt-0123456789abcdef0"
    version = "$Latest"
  }
}

# 2. Política y Alarma para CRECER (Scale-Out)
resource "aws_autoscaling_policy" "escalar_arriba" {
  name                   = "politica-subir-instancias"
  scaling_adjustment     = 1                # Suma 1 instancia
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300              # Espera 5 min antes de volver a actuar
  autoscaling_group_name = aws_autoscaling_group.mis_nodos.name
}

resource "aws_cloudwatch_metric_alarm" "cpu_alta" {
  alarm_name          = "alarma-cpu-alta"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2                  # 2 periodos seguidos
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300                # Cada periodo dura 5 min (300 seg)
  statistic           = "Average"
  threshold           = 75                 # Umbral del 75%

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.mis_nodos.name
  }

  alarm_actions = [aws_autoscaling_policy.escalar_arriba.arn]
}

# 3. Política y Alarma para REDUCIR (Scale-In)
resource "aws_autoscaling_policy" "escalar_abajo" {
  name                   = "politica-bajar-instancias"
  scaling_adjustment     = -1               # Resta 1 instancia
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.mis_nodos.name
}

resource "aws_cloudwatch_metric_alarm" "cpu_baja" {
  alarm_name          = "alarma-cpu-baja"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 3                  # 15 min seguidos (3 x 300 seg)
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  threshold           = 30                 # Umbral del 30%

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.mis_nodos.name
  }

  alarm_actions = [aws_autoscaling_policy.escalar_abajo.arn]
}
