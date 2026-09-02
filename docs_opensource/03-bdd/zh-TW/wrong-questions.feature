Feature: 錯題消滅與弱點強化
  身為考生，
  我想針對常錯題目反覆測驗，
  以迅速消滅知識盲區。

  Scenario: 自動收集錯題至錯題本
    Given 考生答錯一題
    When 測驗結束
    Then 該題自動存入 Cloud Firestore 錯題本集合中
