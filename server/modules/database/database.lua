BennyCserviceDatabase = BennyCserviceDatabase or {}

function BennyCserviceDatabase.Init()
    MySQL.query.await([[
        CREATE TABLE IF NOT EXISTS `benny_cservice` (
            `id` INT NOT NULL AUTO_INCREMENT,
            `identifier` VARCHAR(80) NOT NULL,
            `tasks_remaining` INT NOT NULL DEFAULT 0,
            `total_tasks` INT NOT NULL DEFAULT 0,
            `original_x` FLOAT NOT NULL DEFAULT 0,
            `original_y` FLOAT NOT NULL DEFAULT 0,
            `original_z` FLOAT NOT NULL DEFAULT 0,
            `original_w` FLOAT NOT NULL DEFAULT 0,
            `items_json` LONGTEXT NULL,
            `started_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
            PRIMARY KEY (`id`),
            UNIQUE KEY `identifier` (`identifier`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    ]])

    BennyCserviceDebug.Print('database table ready')

    pcall(function()
        MySQL.query.await('ALTER TABLE benny_cservice ADD COLUMN task_type VARCHAR(32) DEFAULT "m_sweep"')
    end)
end

function BennyCserviceDatabase.GetByIdentifier(m_identifier)
    return MySQL.single.await([[
        SELECT *
        FROM benny_cservice
        WHERE identifier = ?
        LIMIT 1
    ]], { m_identifier })
end

function BennyCserviceDatabase.Upsert(m_identifier, m_data)
    return MySQL.insert.await([[
        INSERT INTO benny_cservice (
            identifier,
            tasks_remaining,
            total_tasks,
            original_x,
            original_y,
            original_z,
            original_w,
            items_json,
            task_type
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
        ON DUPLICATE KEY UPDATE
            tasks_remaining = VALUES(tasks_remaining),
            total_tasks = VALUES(total_tasks),
            original_x = VALUES(original_x),
            original_y = VALUES(original_y),
            original_z = VALUES(original_z),
            original_w = VALUES(original_w),
            items_json = VALUES(items_json),
            task_type = VALUES(task_type),
            started_at = CURRENT_TIMESTAMP
    ]], {
        m_identifier,
        m_data.m_tasks_remaining,
        m_data.m_total_tasks,
        m_data.m_original_x,
        m_data.m_original_y,
        m_data.m_original_z,
        m_data.m_original_w,
        m_data.m_items_json,
        m_data.m_task_type or 'm_sweep',
    })
end

function BennyCserviceDatabase.UpdateTasks(m_identifier, m_tasks_remaining, m_total_tasks)
    if m_total_tasks then
        return MySQL.update.await([[
            UPDATE benny_cservice
            SET tasks_remaining = ?, total_tasks = ?
            WHERE identifier = ?
        ]], { m_tasks_remaining, m_total_tasks, m_identifier })
    end

    return MySQL.update.await([[
        UPDATE benny_cservice
        SET tasks_remaining = ?
        WHERE identifier = ?
    ]], { m_tasks_remaining, m_identifier })
end

function BennyCserviceDatabase.Delete(m_identifier)
    return MySQL.update.await([[
        DELETE FROM benny_cservice
        WHERE identifier = ?
    ]], { m_identifier })
end

function BennyCserviceDatabase.GetAllActive()
    return MySQL.query.await([[
        SELECT *
        FROM benny_cservice
        WHERE tasks_remaining > 0
    ]]) or {}
end
