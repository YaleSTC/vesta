(
  SELECT
    clips.draw_id AS draw_id,
    clips.id AS clip_id,
    NULL AS group_id
  FROM
    clips
)

UNION

(
  SELECT
    groups.draw_id AS draw_id,
    NULL AS clip_id,
    groups.id AS group_id
  FROM
    groups AS groups

  LEFT JOIN clip_memberships

  ON groups.id = clip_memberships.group_id

  WHERE
    clip_memberships.confirmed IS NOT TRUE
)
